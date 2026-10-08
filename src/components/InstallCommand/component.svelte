<script lang="ts">
	import { onDestroy } from 'svelte';

	export let packageName: string;

	let copied: boolean = false;
	let timeout: ReturnType<typeof setTimeout>;

	$: command = `npm install -g ${packageName}`;

	async function copy() {
		try {
			await navigator.clipboard.writeText(command);
			copied = true;
			clearTimeout(timeout);
			timeout = setTimeout(() => (copied = false), 1500);
		} catch {
			copied = false;
		}
	}

	onDestroy(() => clearTimeout(timeout));
</script>

<div class="InstallCommand">
	<code class="InstallCommand__command">
		<span class="InstallCommand__prompt" aria-hidden="true">$</span>
		npm install -g <strong>{packageName}</strong>
	</code>
	<button
		class="InstallCommand__copy"
		type="button"
		aria-label={copied ? 'Copied' : 'Copy install command'}
		title={copied ? 'Copied' : 'Copy'}
		on:click={copy}
	>
		{#if copied}
			<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
				<path
					d="M5 12.5l4.5 4.5L19 7.5"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
				/>
			</svg>
		{:else}
			<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
				<rect
					x="8"
					y="7"
					width="11"
					height="14"
					rx="1.5"
					stroke="currentColor"
					stroke-width="1.6"
				/>
				<path
					d="M5 17V4.5A1.5 1.5 0 0 1 6.5 3H15"
					stroke="currentColor"
					stroke-width="1.6"
					stroke-linecap="round"
				/>
			</svg>
		{/if}
	</button>
</div>

<style lang="scss">
	.InstallCommand {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
		width: 100%;
		max-width: 324px;
		height: 52px;
		padding: 0 12px 0 16px;
		border: 2px solid var(--color-text-strong);
		border-radius: 8px;
		background: var(--color-bg);
	}

	.InstallCommand__command {
		font-family: inherit;
		font-size: 16px;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.InstallCommand__prompt {
		margin-right: 6px;
		color: var(--color-text-muted);
	}

	.InstallCommand__copy {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		width: 32px;
		height: 32px;
		padding: 0;
		border: none;
		border-radius: 6px;
		background: transparent;
		color: var(--color-text-strong);
		cursor: pointer;
		flex-shrink: 0;

		&:hover {
			background: var(--color-surface);
		}

		&:focus-visible {
			outline: 2px solid var(--color-text-strong);
			outline-offset: 2px;
		}
	}
</style>
