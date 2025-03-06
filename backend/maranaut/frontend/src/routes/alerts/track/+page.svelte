<script lang="ts">
	import { onMount } from 'svelte';
	import { Map } from '@onsvisual/svelte-maps';
	import maplibre from 'maplibre-gl';
	import pkg from 'maplibre-gl';
	const { Marker } = pkg;
	let map: Map = $state();
	let center = $state({});
	let zoom = $state(14);
	let longitude = $state(16.62662018);
	let latitude = $state(49.2125578);
	interface DT {
		id: string;
		name: string;
	}
	let data: DT | null = $state(null);
	onMount(async () => {
		map.addControl(new maplibre.NavigationControl(), 'top-left');
		new Marker({ color: 'red' }).setLngLat([longitude, latitude]).addTo(map);

		const response = await fetch('http://localhost:8000/ships/all');
		data = await response.json();
	});
</script>

<div class="flex size-full space-x-2 overflow-y-hidden rounded-xl p-4 text-center">
	<div id="left" class="size-full w-1/4 space-y-2">
		<div class="rounded-tl-lg bg-white/20 p-8">Your Voyages</div>
		{#each data as dt, k (k)}
			<div class="bg-white/20 p-8">
				{dt.ship_name}
			</div>
		{/each}
	</div>
	<div id="right" class="size-full space-y-2">
		<div class="rounded-tr-lg bg-white/20 p-4 text-2xl capitalize">Track your voyage</div>
		<div class="h-full space-y-2 bg-white/20">
			<Map
				id="map"
				style="https://api.maptiler.com/maps/streets/style.json?key=k1lR4JJybsAxuJGkj0Kx"
				location={{ lng: longitude, lat: latitude, zoom: 14 }}
				bind:map
				bind:zoom
				bind:center
			/>
		</div>
	</div>
</div>
