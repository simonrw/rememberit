<script lang="ts">
	import { content } from '$lib/state/localstorage';
	import Entry from '$lib/components/Entry.svelte';
	import { sortEntities, type StructuredEntity } from '$lib/StructuredEntity';

	let entry = '';

	function submit() {
		const structuredEntry: StructuredEntity = {
			content: entry,
			created: new Date()
		};
		content.update((state) => {
			try {
				const prev = JSON.parse(state);
				return JSON.stringify([structuredEntry, ...prev]);
			} catch {
				return JSON.stringify([entry]);
			}
		});
		entry = '';
	}

	function reset() {
		content.set('[]');
	}

	$: decodedState = JSON.parse($content).sort(sortEntities).reverse();
</script>

<button on:click={reset}>Reset entries</button>

<form on:submit|preventDefault={submit}>
	<label for="entry">Entry</label>
	<input name="entry" id="entry" type="text" bind:value={entry} />

	<button>Add entry</button>
</form>

<div>
	{#each decodedState as contentItem}
		<Entry state={contentItem} />
	{/each}
</div>
