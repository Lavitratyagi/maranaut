from typing import List, Any
import re
import requests
from pymongo.collection import Collection, Mapping
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from pymongo import MongoClient
from pydantic import BaseModel
import os
from fastapi.middleware.cors import CORSMiddleware


class User(BaseModel):
    email: str
    password: str
    admin: bool


class Ports(BaseModel):
    locode: str
    name: str
    longitude: float
    latitude: float


class Ship(BaseModel):
    ship_name: str
    id: str
    type: str
    ais: int
    fuel_type: str
    top_speed: int
    ship_dimension: str


class Trip(BaseModel):
    ship_id: str
    src_latitude: float
    src_longitude: float
    dist_latitude: float
    dist_longitude: float
    passengers: int
    available_fuel: float


class Mymongo(FastAPI):
    mongodb_client: MongoClient
    collection_user: Collection[Mapping[str, Any]]
    collection_ship: Collection[Mapping[str, Any]]
    collection_trip: Collection[Mapping[str, Any]]
    collection_trip_history: Collection[Mapping[str, Any]]
    collection_port: Collection[Mapping[str, Any]]


app = Mymongo()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


run_enironment = os.environ.get('local')
if run_enironment:
    DB_URL = 'mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.4.0'
else:
    DB_URL = 'mongodb+srv://test:test@cluster0.yvlq9mj.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'


@app.on_event('startup')
async def startup_client():
    app.mongodb_client = MongoClient(DB_URL)
    app.collection_user = app.mongodb_client['maranaut']['user']
    app.collection_ship = app.mongodb_client['maranaut']['ship']
    app.collection_trip = app.mongodb_client['maranaut']['trip']
    app.collection_trip_history = app.mongodb_client['maranaut']['trip_history']
    app.collection_port = app.mongodb_client['maranaut']['port']


# Routes

# @app.get('/routes/ports')
# async def get_ports(name: str | None) -> List[Ports]:
#     if not name:
#         name = 'India'
#     name = name.lower()

#     ports = app.collection_port.find({"NAME": re.compile('^I', re.IGNORECASE)})
#     ports_list = list()
#     for port in ports:
#         ports_list.append(Ports(
#             locode=port.get('locode', ''),
#             name=port.get('NAME', ''),
#             longitude=port.get('longitude', 0.0),
#             latitude=port.get('latitude', 0.0),
#         ))
#     return ports_list


@app.get('/routes/get-coordinates')
async def get_coordinates(src_coordinates: str, dst_coordinate: str, src_locode: str, dst_locode: str):

    url = "https://route.vesselfinder.com/api/getpath"

    params = {
        "src": "4.342174530029297,51.893033530457416",
        "dst": "103.75659,1.27877",
        "eca": "1",
        "g": "DRAKE-1,KIEL-1,SUEZ-1,PANAMA-1,NORTHEAST-0,NORTHWEST-0,CORINTH-0,MAGELLAN-1,ORESUND-1,MALACCA-1,MESSINA-1",
        "dp": "NLZBW",
        "ap": "SGSIN"
    }

    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0",
        "Accept": "*/*",
        "Accept-Language": "en-US,en;q=0.5",
        "Referer": "https://route.vesselfinder.com/",
        "X-Route-Points": "NLZBW|SGSIN",
        "Cookie": "vfid=eyJhbGciOiJSUzI1NiJ9.eyJ1aWQiOjc3MzAwMCwiciI6MCwiaWRlbnRpdHkiOjc3MzAwMCwiY2wiOjEsImp0aSI6MjIxNzc4MTUsInJtYnIiOnRydWUsImNhIjowLCJleHAiOjE3NDEyMzAwODZ9.SEaRKRUACPwnRYPOABsnhYTpqJhD5_j1V4wJJe9SUN-lHx4TiUPQ2Ne4D8zab-YferUmkK5tILfY73OzEcshIShUEdp9QPQffLrYB-mndpC-7W6KrfrLbmv2_qcUYUWGtzat-3monvKk00eodfQs01JQwu8FnzbxzUWV8Qb3Q56QUn6o2-AUZb4C9KNy4JRWeTj4_aW4urRfHUNbROpqZ9UZqPmeUjk76ql2xURjHN04kbB1x9iEAZIZ0YV4wePBDaGntz4CyP0oCNncZh_uCowgl6B6Bjv4jM1XKVXY-534maT92LmvOZROwACE-ql_RSn6iyb97SC-vSADdmcSWA"
    }

    response = requests.get(
        url,
        params=params,
        headers=headers
    )

    print(response.status_code)
    try:
        return response.json()
    except Exception:
        return response.text

# TRIP


@app.post('/trip/register')
async def register_trip(trip: Trip) -> bool:
    app.collection_trip_history.insert_one({
        'ship_id': trip.ship_id,
        'src_latitude': trip.src_latitude,
        'src_longitude': trip.src_longitude,
        'dist_latitude': trip.dist_latitude,
        'dist_longitude': trip.dist_longitude,
        'passengers': trip.passengers,
        'available_fuel': trip.available_fuel,

    })
    if (app.collection_trip.find_one({'ship_id': trip.ship_id})):
        return False
    app.collection_ship.insert_one({
        'ship_id': trip.ship_id,
        'src_latitude': trip.src_latitude,
        'src_longitude': trip.src_longitude,
        'dist_latitude': trip.dist_latitude,
        'dist_longitude': trip.dist_longitude,
        'passengers': trip.passengers,
        'available_fuel': trip.available_fuel,
    })
    return True


@app.get('/trip')
async def get_trip(id: str) -> Trip | bool:
    if (trip := app.collection_ship.find_one({'ship_id': id})):
        return Trip(
            ship_id=trip.get('ship_id', ''),
            src_latitude=trip.get('src_latitude', ''),
            src_longitude=trip.get('src_longitude', ''),
            dist_latitude=trip.get('dist_latitude', ''),
            dist_longitude=trip.get('dist_longitude', ''),
            passengers=trip.get('passengers', ''),
            available_fuel=trip.get('available_fuel', ''),
        )
    return False


@app.get('/trip/history')
async def get_trip_history(id: str) -> List[Trip] | bool:
    history: List[Trip] = list()
    if (trips := app.collection_trip_history.find({'ship_id': id})):
        for trip in trips:
            history.append(Trip(
                ship_id=trip.get('ship_id', ''),
                src_latitude=float(trip.get('src_latitude', 0.0)),
                src_longitude=float(trip.get('src_longitude', 0.0)),
                dist_latitude=float(trip.get('dist_latitude', 0.0)),
                dist_longitude=float(trip.get('dist_longitude', 0.0)),
                passengers=int(trip.get('passengers', 0)),
                available_fuel=float(trip.get('available_fuel', 0.0)),
            ))
        return history
    return False

# SHIP


@app.post('/ships/create')
async def ship_create(ship: Ship) -> bool:
    if (app.collection_ship.find_one({"id": ship.id})):
        return False
    if not ship.id:
        return False
    app.collection_ship.insert_one({
        'ship_name': ship.ship_name,
        'id': ship.id,
        'type': ship.type,
        'ais': ship.ais,
        'fuel_type': ship.fuel_type,
        'top_speed': ship.top_speed,
        'ship_dimension': ship.ship_dimension,
    })
    return True


@app.get('/ships')
async def get_ship(id: str) -> Ship | bool:
    if (ship := app.collection_ship.find_one({"id": id})):
        return Ship(
            ship_name=ship.get('ship_name', ''),
            id=id,
            type=ship.get('type', ''),
            ais=ship.get('ais', ''),
            fuel_type=ship.get('fuel_type', ''),
            top_speed=ship.get('top_speed', ''),
            ship_dimension=ship.get('ship_dimension', ''),
        )

    return False


@app.get('/ships/all')
async def get_ship_all() -> List[Ship] | bool:
    ship_list: List[Ship] = []
    if (ships := app.collection_ship.find({})):
        for ship in ships:
            ship_list.append(Ship(
                ship_name=ship.get('ship_name', ''),
                id=ship.get('id', ''),
                type=ship.get('type', ''),
                ais=int(ship.get('ais', 0)),
                fuel_type=ship.get('fuel_type', ''),
                top_speed=int(ship.get('top_speed', 0)),
                ship_dimension=ship.get('ship_dimension', ''),
            )
            )
        return ship_list

    return False


# ACCOUNT

@app.post('/account/create')
async def create(user: User) -> bool:
    if (app.collection_user.find_one({"email": user.email})):
        return False
    app.collection_user.insert_one({
        'email': user.email,
        'password': user.password,
        'admin': user.admin,
    })
    return True


@app.get('/account/login')
async def login(email: str, password: str) -> User | bool:
    if (usr := app.collection_user.find_one({"email": email, "password": password})):
        return User(
            email=usr.get("email", ""),
            admin=usr.get("admin", ""),
            password=usr.get("password", ""),
        )
    return False


@app.on_event("shutdown")
def shutdown_db_client():
    app.mongodb_client.close()


# @app.websocket('/broadcast')
# async def broadcast(ws: WebSocket):
#     data = await ws.accept()
#     while True:
#         await ws.send_text("This is broadcasting")


class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast_bytes(self, message: bytes, sender: WebSocket | None = None):
        for connection in self.active_connections.copy():
            if connection != sender:
                try:
                    await connection.send_bytes(message)
                except Exception:
                    self.disconnect(connection)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str, sender: WebSocket | None = None):
        for connection in self.active_connections.copy():
            if connection != sender:
                try:
                    await connection.send_text(message)
                except Exception:
                    self.disconnect(connection)


manager = ConnectionManager()


@app.websocket("/broadcast/alerts")
async def broadcast(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.broadcast(data)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception as e:
        manager.disconnect(websocket)
        raise e


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
