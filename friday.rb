class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/friday_releases"
  version "1.6.3"

  # Use a conditional URL based on architecture
  if Hardware::CPU.arm?
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/assets/250501557", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "7eddb392f5cd1445d6d29cbb53ad49852efa48c5f1f9b7bc37c6456fdc85e264"
  else
    # Dummy URL to satisfy Homebrew
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/latest", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "dummy"
  end

  depends_on arch: :arm64
  depends_on "gh"
  depends_on "fd"
  depends_on "ripgrep"

  def install
    if !Hardware::CPU.arm?
      odie "Friday is only available for Apple Silicon (ARM) Macs. Your computer has an Intel processor which is not supported."
    end

    # Rename the actual binary to friday-bin
    bin.install "friday" => "friday-bin"
    chmod 0755, bin/"friday-bin"

    # Create wrapper script for friday
    (bin/"friday").write <<~EOS
      #!/bin/bash
      if [[ "$1" == "--version" ]]; then
        echo "Friday #{version}"
        exit 0
      fi
      exec "#{bin}/friday-bin" "$@"
    EOS
    chmod 0755, bin/"friday"
    (etc/"friday").mkpath
    branch_config = etc/"friday/.branch_config.yaml"
    unless branch_config.exist?
      branch_config.write "{}\n"
    end
  end

  def post_install
    puts "\n📝 Configuration Required:"
    puts "1. Login to GitHub CLI:"
    puts "   gh auth login"
    puts ""
    puts "🚀 Start Friday:"
    puts "   cd <path/to/your/git/repo> && friday"
    puts ""
    puts "📋 Additional Commands:"
    puts "   friday --version    # Display version information"
    puts "   friday --help       # Display help information"
  end

  test do
    if !Hardware::CPU.arm?
      odie "Friday is only available for Apple Silicon (ARM) Macs."
    else
      system "#{bin}/friday"
    end
  end
end
