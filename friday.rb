class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/auto_coder"
  version "stable"

  on_arm do
    url "https://api.github.com/repos/HeadstartAI/auto_coder/releases/assets/227686431", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream",
               "Authorization: token #{ENV['HOMEBREW_GITHUB_API_TOKEN']}"]
    sha256 "a648a461aa1c245bedaba99526cc96879542571267e5312ed9639b204d624270"
  end

  depends_on arch: :arm64
  depends_on "gh"
  depends_on "fd"
  depends_on "ripgrep"

  def install
    bin.install "friday"
    chmod 0755, bin/"friday"

    (etc/"friday").mkpath
    (etc/"friday/.branch_config.yaml").write "{}\n"
  end

  def post_install
    puts "\n📝 Configuration Required:"
    puts "1. Create ~/.friday.env with your environment variables:"
    puts "Example:"
    puts "  OPENAI_API_KEY=your_key_here"
    puts "  ANTHROPIC_API_KEY=your_token_here"
    puts "\n2. Login to GitHub CLI:"
    puts "  Run 'gh auth login' and follow the prompts"
    puts "\nRun 'friday <base_path>' after completing the setup"
  end

  test do
    system "#{bin}/friday"
  end
end
