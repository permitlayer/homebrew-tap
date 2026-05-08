# Homebrew formula for agentsso, the permitlayer daemon binary.
class Agentsso < Formula
  desc "Binary: axum server, CLI, lifecycle management"
  homepage "https://github.com/permitlayer/permitlayer"
  version "0.3.0-rc.16"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.16/permitlayer-daemon-aarch64-apple-darwin.tar.xz"
      sha256 "bb6b24b4e749ae66bce68a4a7437820dc7361e91eac6591dc9d8c23f8e3fd054"
    end
    if Hardware::CPU.intel?
      url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.16/permitlayer-daemon-x86_64-apple-darwin.tar.xz"
      sha256 "74128171722783e00b54afe51603f135fd6fa5fcf8932e9ac6a8ada4dab37a68"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/permitlayer/permitlayer/releases/download/v0.3.0-rc.16/permitlayer-daemon-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "414880e6b2b1d8ad40b3c4118b0f9209ca5362216b30b4fcf63f65c26b7c0128"
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
