<script lang="ts">
	import { NavLink, InstallCommand, Stat } from '@components';

	const PACKAGE_NAME = 'nuke-cli';
	const LATEST_VERSION = '1.1.8';
	const TOTAL_DOWNLOADS = '205';
</script>

<div class="Page">
	<nav class="Page__nav" aria-label="External links">
		<NavLink href="https://www.npmjs.com/package/nuke-cli" label="npm" />
		<NavLink href="https://github.com/cl4pper/nuke-cli" label="GitHub" />
	</nav>

	<main class="Page__hero">
		<div class="Hero">
			<div class="Hero__heading">
				<h1 class="Hero__title">{PACKAGE_NAME}</h1>
				<span class="Hero__logo" aria-hidden="true" />
			</div>
			<p class="Hero__tagline">A simple way to start <br />your next web project.</p>
			<InstallCommand packageName={PACKAGE_NAME} />
		</div>
	</main>

	<footer class="Page__footer">
		<div class="Hero Page__stats">
			<Stat value={LATEST_VERSION} label="latest version" />
			<Stat value={TOTAL_DOWNLOADS} label="total downloads" />
		</div>
	</footer>
</div>

<style lang="scss">
	.Page {
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	.Page__nav {
		display: flex;
		justify-content: flex-end;
		gap: 48px;
		padding: 24px;
	}

	.Page__hero {
		display: flex;
		flex: 1;
		align-items: center;
		justify-content: center;
		padding: 48px 16px;
	}

	.Hero {
		width: 100%;
		max-width: 346px;
	}

	.Hero__heading {
		display: flex;
		align-items: center;
		gap: 24px;
	}

	.Hero__title {
		margin: 0;
		font-size: 64px;
		font-weight: 700;
		letter-spacing: -0.02em;
		line-height: 1.1;
		color: var(--color-text-strong);
	}

	.Hero__logo {
		width: 64px;
		height: 64px;
		border-radius: 50%;
		background: var(--color-surface);
		flex-shrink: 0;
	}

	.Hero__tagline {
		margin: 28px 0 22px;
		font-size: 24px;
		line-height: 1.2;
	}

	.Page__footer {
		display: flex;
		justify-content: center;
		padding: 20px 16px;
		background: var(--color-surface);
	}

	.Page__stats {
		display: grid;
		grid-template-columns: repeat(2, max-content);
		gap: 16px 120px;
	}

	@media (max-width: 480px) {
		.Page__nav {
			gap: 12px;
			padding: 16px;
		}

		.Hero__title {
			font-size: 44px;
		}

		.Hero__logo {
			width: 48px;
			height: 48px;
		}

		.Hero__tagline {
			font-size: 20px;
		}

		.Page__stats {
			column-gap: 48px;
		}
	}
</style>
