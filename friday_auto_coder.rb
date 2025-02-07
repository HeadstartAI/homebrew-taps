class FridayAutoCoder < Formula
  desc "Friday AutoCoder"
  homepage "https://github.com/HeadstartAI/auto_coder"
  url "https://api.github.com/repos/HeadstartAI/auto_coder/tarball/v1.2", using: :curl,
    headers: ["Accept: application/vnd.github.v3.raw",
             "Authorization: token #{ENV['HOMEBREW_GITHUB_API_TOKEN']}"]
  sha256 "96fb2fba25bc8cc7e29d4d56d485b1f5e82594aea51c122aa2d5f13b5ada9daa"

  # Add your dependencies
  depends_on "poetry"
  depends_on "gh"
  depends_on "fd"
  depends_on "ripgrep"  # this is the package name for 'rg'

  def install
    libexec.install Dir["*"]

    cd libexec do
      # Force poetry to create virtualenv in project directory
      system "poetry", "config", "virtualenvs.in-project", "true", "--local"
      system "poetry", "install", "--no-interaction", "--no-ansi"
    end

    # Modify bin/run to use .friday_auto_coder.env
    inreplace "#{libexec}/bin/run",
      'if [ ! -f "$PROJECT_ROOT/.env" ]; then',
      'if [ ! -f "$HOME/.friday_auto_coder.env" ]; then'

    inreplace "#{libexec}/bin/run",
      'source "$PROJECT_ROOT/.env"',
      'source "$HOME/.friday_auto_coder.env"'

    # Create the wrapper script
    (bin/"friday_auto_coder").write <<~EOS
      #!/bin/bash
      exec #{libexec}/bin/run "$@"
    EOS

    chmod 0755, bin/"friday_auto_coder"
  end

  def post_install
    puts "\n📝 Configuration Required:"
    puts "1. Create ~/.friday_auto_coder.env with your environment variables:"
    puts "Example:"
    puts "  OPENAI_API_KEY=your_key_here"
    puts "  ANTHROPIC_API_KEY=your_token_here"
    puts "\n2. Login to GitHub CLI:"
    puts "  Run 'gh auth login' and follow the prompts"
    puts "\nRun 'friday_auto_coder <base_path>' after completing the setup"
  end

  test do
    system "#{bin}/friday_auto_coder", "--version"
  end
end

