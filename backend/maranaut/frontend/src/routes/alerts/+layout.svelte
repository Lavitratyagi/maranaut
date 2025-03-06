<script lang="ts">
	let { children } = $props();
</script>

<div class="app">
	<main class="flex h-screen w-screen flex-col bg-[url(/bg.png)] bg-cover text-white">
		<div class="flex h-fit w-full justify-start p-4">
			<img src="/logo.png" alt="logo" class="mt-4 size-fit" />
			<nav
				class="mt-4 ml-44 flex w-1/2 items-center justify-between space-x-4 rounded-xl bg-gray-600 p-4 px-8 text-center font-serif text-xl uppercase"
			>
				<a href="/" class="text-white hover:underline"> Home </a>
				<a href="/alerts" class="text-white hover:underline"> Alert </a>
				<a href="/alerts/track" class="text-white hover:underline"> Track </a>
			</nav>
			<div></div>
		</div>
		<div class="m-24 flex h-screen items-center justify-center">
			{@render children()}
		</div>
	</main>
</div>
