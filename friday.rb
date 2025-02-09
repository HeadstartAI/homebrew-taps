class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/auto_coder"
  url "https://api.github.com/repos/HeadstartAI/auto_coder/tarball/v1.2.2", using: :curl,
    headers: ["Accept: application/vnd.github.v3.raw",
             "Authorization: token #{ENV['HOMEBREW_GITHUB_API_TOKEN']}"]
  sha256 "84c4e55650c8e85ebf5347ce88e0cff490839a2c696b88d0d99558b8df73de71"

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
      system "mkdir", "-p", "app/cli/config"
      File.write("app/cli/config/.branch_config.yaml", "{}\n")
    end

    # Create the wrapper script
    (bin/"friday").write <<~EOS
      #!/bin/bash
      exec #{libexec}/bin/run "$@"
    EOS

    chmod 0755, bin/"friday"
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
    system "#{bin}/friday", "--version"
  end
end

