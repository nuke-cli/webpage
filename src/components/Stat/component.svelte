<script lang="ts">
	import Text from '../Text/component.svelte';

	export let value: string;
	export let label: string;
</script>

<div class="Stat">
	<span class="Stat__value">{value}</span>
	<Text size="md">{label}</Text>
</div>

<style lang="scss">
	.Stat {
		display: flex;
		flex-direction: column;
		gap: 2px;

		:global(p) {
			margin: 0;
		}
	}

	.Stat__value {
		font-size: 32px;
		font-weight: 700;
		line-height: 1.1;
		color: var(--color-text-strong);
	}
</style>
