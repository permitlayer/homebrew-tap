# homebrew-tap

Homebrew tap for [permitlayer](https://github.com/permitlayer/permitlayer) — an open-core agent identity and data layer.

## Install

```
brew tap permitlayer/tap
brew install permitlayer/tap/agentsso
```

Run the daemon under Homebrew-managed `launchd` (optional):

```
brew services start agentsso
```

Or start it yourself:

```
agentsso start
```

See the [main repo](https://github.com/permitlayer/permitlayer) for documentation.

## About this tap

This repository is auto-updated by the `homebrew-publish` job in
[permitlayer/permitlayer's release pipeline](https://github.com/permitlayer/permitlayer/blob/main/.github/workflows/release.yml).
Direct PRs to `Formula/agentsso.rb` will be closed; file issues on the
main repo instead.

## License

MIT — see [LICENSE](LICENSE).
