# Homebrew formula for agentsso, the permitlayer daemon binary.
class Agentsso < Formula
  desc "Binary: axum server, CLI, lifecycle management"
  homepage "https://github.com/permitlayer/permitlayer"
  version "0.3.0-rc.23"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.23/permitlayer-daemon-aarch64-apple-darwin.tar.xz"
      sha256 "e4b4464ee7858cfe58e667a1bacc608101e6c3b928b89cb6786a38077be0265c"
    end
    if Hardware::CPU.intel?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.23/permitlayer-daemon-x86_64-apple-darwin.tar.xz"
      sha256 "809c4242c7754052a59f65eceb960e7855a61ed05b235bcd2c8bbf7276ec2a55"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.23/permitlayer-daemon-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "c8e5acb106fd2055f7d06fb14e47fe5789e1e5350f30d3fab66777040ff085f6"
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
