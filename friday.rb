class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/friday_releases"
  version "1.17.0-rev.0"

  # Use a conditional URL based on architecture
  if Hardware::CPU.arm?
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/assets/307857515", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "9cf031289887d963ffcf0d3c4c2b11a9b8ffd826f771dc7f04c8cfa0ef2ca3b9"
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
  depends_on "node@22"

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
    env_file = etc/"friday/.env"
    unless env_file.exist?
      env_file.write ""
    end
  end

  def post_install
    node_version_output = `node --version 2>/dev/null`.strip
    if node_version_output =~ /v(\d+)\./
      major_version = $1.to_i
      if major_version < 22
        puts "⚠️ Friday requires Node.js v22 or higher."
        puts "   Current version: #{node_version_output}"
        puts "   Please make Node.js v22+ active in your PATH and restart your terminal."
        puts ""
      end
    end

    npx_check = `command -v npx 2>/dev/null`.strip
    if npx_check.empty?
      puts "⚠️ npx not found in your PATH. Friday requires npx to function properly."
      puts "   Node.js should have been installed as a dependency, but you may need to restart your terminal."
      puts "   Verify installation with: node --version && npx --version"
    end
    puts ""
    puts "📝 Configuration Required:"
    puts "1. Login to GitHub CLI:"
    puts "   gh auth login"
    puts ""
    puts "🚀 Start Friday:"
    puts "   cd <path/to/your/git/repo> && friday"
    puts ""
    puts "📋 Additional Commands:"
    puts "   friday --version    # Display version information"
    puts "   friday --help       # Display help information"
    puts ""
  end

  test do
    if !Hardware::CPU.arm?
      odie "Friday is only available for Apple Silicon (ARM) Macs."
    else
      system "which", "npx"
      system "#{bin}/friday"
    end
  end
end
