# Homebrew formula for agentsso, the permitlayer daemon binary.
class Agentsso < Formula
  desc "Binary: axum server, CLI, lifecycle management"
  homepage "https://github.com/permitlayer/permitlayer"
  version "0.3.0-rc.19"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.19/permitlayer-daemon-aarch64-apple-darwin.tar.xz"
      sha256 "91dc811c782d2b8a61a8afa3e7be305b8d8ecda488bf849d2c0851abdbfa91d1"
    end
    if Hardware::CPU.intel?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.19/permitlayer-daemon-x86_64-apple-darwin.tar.xz"
      sha256 "c58b941704851007173807f1776905f6a87d764d54bc8d71cfb33d31a61da50f"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.19/permitlayer-daemon-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "757b041cb5a920228585f5a554ade96c2b83c471466f0b66ba582f07a14455c7"
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

          1. Create a Desktop OAuth client at
             https://console.cloud.google.com/apis/credentials and
             download the JSON ("client_secret_XXXX.json").
          2. Connect a service, pointing at that JSON:

                 agentsso connect gmail --oauth-client ./client_secret.json --agent <name>

             For SSH-from-another-machine, add --headless. The bare
             `agentsso connect gmail` will interactively prompt for the
             file path if you forget the flag.

      Start the daemon yourself:

          agentsso start

      Enable login-autostart so the daemon comes up automatically at
      login (Story 7.16: SSH-friendly — no GUI session required, works
      over SSH on macOS 13+):

          agentsso autostart enable

      Docs: https://github.com/permitlayer/permitlayer
    EOS
  end
end
