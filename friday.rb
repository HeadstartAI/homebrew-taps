class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/auto_coder"
  version "stable"

  on_arm do
    url "https://api.github.com/repos/HeadstartAI/auto_coder/releases/assets/229189856", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream",
               "Authorization: token #{ENV['HOMEBREW_GITHUB_API_TOKEN']}"]
    sha256 "bbb1f0d2f8d9186d12c7b86c29dda92192b4a25f7a6603228d0be6a8ba723f13"
  end

  depends_on arch: :arm64
  depends_on "gh"
  depends_on "fd"
  depends_on "ripgrep"

  def install
    bin.install "friday"
    chmod 0755, bin/"friday"

    (etc/"friday").mkpath

    branch_config = etc/"friday/.branch_config.yaml"
    unless branch_config.exist?
      branch_config.write "{}\n"
    end

    env_file = etc/"friday/.friday.env"
    unless env_file.exist?
      env_file.write <<~EOS
        # Environment variables for Friday
        OPENAI_API_KEY=your_key_here
        ANTHROPIC_API_KEY=your_token_here
      EOS
    end
  end

  def post_install
    puts "\n📝 Configuration Required:"
    puts "Your environment file is now located at: /opt/homebrew/etc/friday/.friday.env"
    puts "1. Edit it with your API keys:"
    puts "   nano /opt/homebrew/etc/friday/.friday.env"
    puts "2. Login to GitHub CLI:"
    puts "   gh auth login"
    puts "\nRun 'friday <base_path>' after completing the setup."
  end

  test do
    system "#{bin}/friday"
  end
end
