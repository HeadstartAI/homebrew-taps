class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/friday_releases"
  version "2.11.1"

  # Use a conditional URL based on architecture
  if Hardware::CPU.arm?
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/assets/375040283", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "2ae66df2781de5d74c61fb8b556ee390e5cc24acfcd5a23a034640d4437f7ebd"
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
  depends_on "expat"
  depends_on "python@3.12"

  def install
    if !Hardware::CPU.arm?
      odie "Friday is only available for Apple Silicon (ARM) Macs. Your computer has an Intel processor which is not supported."
    end

    # Rename the actual binary to friday-bin
    bin.install "friday" => "friday-bin"
    chmod 0755, bin/"friday-bin"

    # Create wrapper script for friday
    # Sets DYLD_LIBRARY_PATH to use Homebrew expat, fixing pyexpat dlopen error
    # where system libexpat stub is missing _XML_SetAllocTrackerActivationThreshold
    (bin/"friday").write <<~EOS
      #!/bin/bash
      case "$1" in
        --version)
          echo "Friday #{version}"
          exit 0
          ;;
        --update)
          brew update && brew upgrade friday
          exit $?
          ;;
      esac
      export DYLD_LIBRARY_PATH="#{Formula["expat"].opt_lib}:${DYLD_LIBRARY_PATH}"
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
    puts "📝 Configuration Required:"
    puts "1. Login to GitHub CLI:"
    puts "   gh auth login"
    puts ""
    puts "🚀 Start Friday:"
    puts "   cd <path/to/your/git/repo> && friday"
    puts ""
    puts "📋 Additional Commands:"
    puts "   friday --version    # Display version information"
    puts "   friday --update     # Update Friday to the latest version"
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
