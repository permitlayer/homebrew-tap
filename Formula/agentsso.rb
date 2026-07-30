# Homebrew formula for agentsso, the permitlayer daemon binary.
class Agentsso < Formula
  desc "Binary: axum server, CLI, lifecycle management"
  homepage "https://github.com/permitlayer/permitlayer"
  version "1.3.2"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/permitlayer/permitlayer/releases/download/v1.3.2/permitlayer-daemon-aarch64-apple-darwin.tar.xz"
      sha256 "76fcb88459c68fde148b83fed4a2a1ac808b4cede73c7f9f7b5c9f5f1bf2a99e"
    end
    if Hardware::CPU.intel?
      url "https://github.com/permitlayer/permitlayer/releases/download/v1.3.2/permitlayer-daemon-x86_64-apple-darwin.tar.xz"
      sha256 "cc62ef465b690cfc0a4b37bf8bd831c35c4307ea215dcbe0a233d75f259012d3"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/permitlayer/permitlayer/releases/download/v1.3.2/permitlayer-daemon-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "0e15213a86f1333176a1de78858c24af27b8fdd8135b0bb57cfd8f33820ea31b"
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

             sudo agentsso setup

         macOS will display a "Background item added" notification. If
         the daemon doesn't appear running, check
         System Settings → General → Login Items → Allow in the Background.

      2. From your end-user account, connect ONE agent to ONE Google
         service in a single command. Create a Desktop OAuth client at
         https://console.cloud.google.com/apis/credentials, download
         the JSON, then run (gmail | calendar | drive):

             agentsso quickstart gmail --read --oauth-client ./client_secret.json

         Use --read for read-only or --read-write for read+write. The
         bearer token is written to ~/.agentsso/agent-bearer.token and
         is the credential your MCP client (OpenClaw / Claude Desktop /
         Cursor) authenticates with. Add --mcp-config-out <path> to emit
         the client's MCP config snippet.

      Verify the daemon is up:

          agentsso service status

      Daemon logs:

          /Library/Logs/permitlayer/daemon.log

      Docs: https://github.com/permitlayer/permitlayer
    EOS
  end
end
