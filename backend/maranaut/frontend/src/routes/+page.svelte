<script lang="ts">
	let voyage = $state(false);
	let ship_name = $state('');
	let ship_model = $state('');
	let ship_length = $state('');
	let ship_id = $state('');
	let fuel_type = $state('');
	let ship_width = $state('');
	let ais_number = $state(0);
	let top_speed = $state(0);
	let total_capacity = $state('');
</script>

<div class="app">
	<main class="flex h-screen w-screen flex-col bg-[url(/bg.png)] bg-cover text-white">
		<div class="flex h-fit w-full justify-start p-4">
			<img src="logo.png" alt="logo" class="mt-4 size-fit" />
			<nav
				class="mt-4 ml-44 flex w-1/2 items-center justify-between space-x-4 rounded-xl bg-gray-600 p-4 px-8 text-center font-serif text-xl uppercase"
			>
				<a href="/" class="text-white hover:underline"> Home </a>
				<a href="/alerts" class="text-white hover:underline"> Alert </a>
				<a href="/alerts/track" class="text-white hover:underline"> Track </a>
			</nav>
			<div></div>
		</div>
		<div class="flex h-screen flex-col items-center justify-center">
			{#if !voyage}
				<div class="flex flex-col items-center justify-center">
					<div class="text-8xl font-extrabold">MaraNaut</div>
					<div class="text-5xl">Let’s manage your Marine Journey.</div>
					<button
						class="my-6 rounded-full border-2 border-blue-700 bg-black p-2 px-4 font-bold uppercase shadow-sm shadow-blue-300"
						onclick={() => (voyage = true)}
					>
						Add Voyages</button
					>
				</div>
				<div class="mt-8 flex space-x-8 font-bold text-black uppercase">
					<div class="rounded-lg bg-pink-100 p-8">Ai Re-Routing</div>
					<div class="rounded-lg bg-purple-100 p-8">Analytics</div>
					<div class="rounded-lg bg-blue-300 p-8">Route Optimization</div>
					<div class="rounded-lg bg-yellow-100 p-8">Fuel Efficiency</div>
				</div>
			{:else}
				<div class="items-left flex h-1/2 flex-col justify-center text-left">
					<div class="mb-4 text-5xl font-extrabold capitalize">details of voyage</div>
					<div class="flex w-[86em] flex-col rounded-md bg-white/20 p-10 text-gray-300">
						<div class="flex justify-between space-x-8">
							<div class="flex flex-col space-y-8">
								Name of ship
								<input bind:value={ship_name} class="rounded-lg border-white bg-transparent" />
								Model/Type of ship
								<input bind:value={ship_model} class="rounded-lg border-white bg-transparent" />
								Ship Length (in meters)
								<input
									bind:value={ship_length}
									type="number"
									class="rounded-lg border-white bg-transparent"
								/>
							</div>
							<div class="flex flex-col space-y-8">
								Enter Ship ID
								<input bind:value={ship_id} class="rounded-lg border-white bg-transparent" />
								Fuel Type
								<input bind:value={fuel_type} class="rounded-lg border-white bg-transparent" />
								Ship in Width (in Beams)
								<input
									bind:value={ship_width}
									type="number"
									class="rounded-lg border-white bg-transparent"
								/>
							</div>
							<div class="flex flex-col space-y-8">
								Enter AIS Number
								<input
									bind:value={ais_number}
									type="number"
									class="rounded-lg border-white bg-transparent"
								/>
								Top Speed (in Knots)
								<input
									bind:value={top_speed}
									type="number"
									class="rounded-lg border-white bg-transparent"
								/>
								Total Capacity
								<input bind:value={total_capacity} class="rounded-lg border-white bg-transparent" />
							</div>
						</div>
						<div class="mt-8 p-4 text-center">
							<button
								class="rounded-full bg-white p-2 px-4 font-bold text-black uppercase shadow-sm shadow-white"
								onclick={async() => {
									voyage = false;
									await fetch('http://localhost:8000/ships/create', {
										method: 'POST',
										headers: {
											'Content-Type': 'application/json'
										},
										body: JSON.stringify({
											ship_name,
											type: ship_model,
											id: ship_id,
											fuel_type,
											ship_dimension: `${ship_length} ${ship_width}`,
											ais: ais_number,
											top_speed,
											total_capacity
										})
									});
								}}>Submit details</button
							>
						</div>
					</div>
				</div>
			{/if}
		</div>
	</main>
</div>
