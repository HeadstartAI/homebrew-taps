class FridayBeta < Formula
  desc "Friday (Beta channel)"
  homepage "https://github.com/HeadstartAI/friday_releases"
  version "2.9.2"

  # Use a conditional URL based on architecture
  if Hardware::CPU.arm?
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/assets/355509685", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "2886386b911aeca8255c94b15873a25241f25d5674e048ff09ce0aebccb9e976"
  else
    # Dummy URL to satisfy Homebrew
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/tags/beta", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "dummy"
  end

  keg_only :versioned_formula

  depends_on arch: :arm64
  depends_on "gh"
  depends_on "fd"
  depends_on "ripgrep"
  depends_on "node@22"
  depends_on "python@3.12"

  def install
    if !Hardware::CPU.arm?
      odie "Friday Beta is only available for Apple Silicon (ARM) Macs. Your computer has an Intel processor which is not supported."
    end

    # Rename the actual binary to friday-bin
    bin.install "friday" => "friday-bin"
    chmod 0755, bin/"friday-bin"

    # Create wrapper script for friday
    (bin/"friday").write <<~EOS
      #!/bin/bash
      case "$1" in
        --version)
          echo "Friday (Beta) #{version}"
          exit 0
          ;;
        --update)
          brew update && brew upgrade friday-beta
          exit $?
          ;;
      esac
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
    puts ""
    puts "📝 Beta Version Configuration Required:"
    puts "1. Login to GitHub CLI:"
    puts "   gh auth login"
    puts ""
    puts "📋 To use this beta version:"
    puts "   If you have the stable version installed:"
    puts "   brew unlink friday && brew link --force friday-beta"
    puts ""
    puts "   If you don't have the stable version installed:"
    puts "   brew link --force friday-beta"
    puts ""
    puts "📋 To switch back to stable version later:"
    puts "   brew unlink friday-beta && brew link friday"
    puts ""
    puts "🚀 Start Friday:"
    puts "   cd <path/to/your/git/repo> && friday"
    puts ""
    puts "📋 Additional Commands:"
    puts "   friday --version    # Display version information"
    puts "   friday --update     # Update Friday Beta to the latest version"
    puts "   friday --help       # Display help information"
    puts ""
  end

  test do
    if !Hardware::CPU.arm?
      odie "Friday Beta is only available for Apple Silicon (ARM) Macs."
    else
      system "which", "npx"
      system "#{bin}/friday"
    end
  end
end
