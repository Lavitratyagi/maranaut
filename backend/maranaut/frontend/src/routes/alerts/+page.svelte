<script lang="ts">
	import { onMount } from 'svelte';

	interface DT {
		id: string;
		name: string;
	}
	let data: DT | null = $state(null);
	onMount(async () => {
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
		<div class="rounded-tr-lg bg-white/20 p-4">Complaints (Alert)</div>
		<div class="h-full space-y-2 bg-white/20">
			<div class="mx-2 rounded-md bg-white p-4 text-black">
				Severe storm en route. Requesting update docking instructions.
			</div>
			<div class="mx-2 rounded-md bg-white p-4 text-black">
				Engine failure. Estimated drift towards [Coordinates]. Requesting tugboat support.
			</div>
		</div>
	</div>
</div>
