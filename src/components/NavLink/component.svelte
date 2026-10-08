<script lang="ts">
	export let href: string;
	export let label: string;
</script>

<a class="NavLink" {href} target="_blank" rel="noopener noreferrer">
	<span class="NavLink__icon" aria-hidden="true" />
	{label}
</a>

<style lang="scss">
	.NavLink {
		display: inline-flex;
		align-items: center;
		gap: 8px;
		min-width: 120px;
		height: 48px;
		padding: 0 16px;
		border-radius: 6px;
		background: var(--color-surface);
		color: var(--color-text);
		font-size: 16px;
		text-decoration: none;
		transition: background 0.15s ease;

		&:hover {
			background: var(--color-surface-hover);
		}

		&:focus-visible {
			outline: 2px solid var(--color-text);
			outline-offset: 2px;
		}
	}

	.NavLink__icon {
		width: 24px;
		height: 24px;
		border-radius: 50%;
		background: var(--color-text-strong);
		flex-shrink: 0;
	}
</style>
