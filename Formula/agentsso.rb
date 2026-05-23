# Homebrew formula for agentsso, the permitlayer daemon binary.
class Agentsso < Formula
  desc "Binary: axum server, CLI, lifecycle management"
  homepage "https://github.com/permitlayer/permitlayer"
  version "0.3.0-rc.41"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.41/permitlayer-daemon-aarch64-apple-darwin.tar.xz"
      sha256 "6b804d010ff2e9f7b3bed6225421cce9654a24ccb8165d320f1bc7219efec18b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.41/permitlayer-daemon-x86_64-apple-darwin.tar.xz"
      sha256 "fc5e850d870bbb4ca0b976f7c2bd0fafb3fa5dc4bce63473fa6fb8be194b149c"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.41/permitlayer-daemon-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "a0995bf7096be27d0afe95c2e28ea847d4337d124212b5995e940aec37503d74"
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":     {},
    "x86_64-apple-darwin":      {},
    "x86_64-pc-windows-gnu":    {},
    "x86_64-unknown-linux-gnu": {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "agentsso" if OS.mac? && Hardware::CPU.arm?
    bin.install "agentsso" if OS.mac? && Hardware::CPU.intel?
    bin.install "agentsso" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end

  def caveats
    <<~EOS
      permitlayer is installed. To get started:

      1. Set up the system service (one-time, per machine):

             sudo agentsso service install

         macOS will display a "Background item added" notification. If
         the daemon doesn't appear running, check
         System Settings → General → Login Items → Allow in the Background.

      2. From your end-user account, register an agent and mint a
         bearer token:

             agentsso agent register <name> --policy <policy-name>

         The token is written to ~/.agentsso/agent-bearer.token and is
         the credential your MCP client (OpenClaw / Claude Desktop /
         Cursor) authenticates with.

      3. Connect a service. Create a Desktop OAuth client at
         https://console.cloud.google.com/apis/credentials, download
         the JSON, and run:

             agentsso connect gmail --oauth-client ./client_secret.json --agent <name>

         For SSH-from-another-machine, add --headless.

      Verify the daemon is up:

          agentsso service status

      Daemon logs:

          /Library/Logs/permitlayer/daemon.log

      Docs: https://github.com/permitlayer/permitlayer
    EOS
  end
end
