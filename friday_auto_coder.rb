class FridayAutoCoder < Formula
  desc "Friday AutoCoder"
  homepage "https://github.com/HeadstartAI/auto_coder"
  url "https://api.github.com/repos/HeadstartAI/auto_coder/tarball/1.1", using: :curl,
    headers: ["Accept: application/vnd.github.v3.raw",
             "Authorization: token #{ENV['HOMEBREW_GITHUB_API_TOKEN']}"]
  sha256 "f3450ceffb845eb13bd525dac83655bc5b50b18d5519e7c83aadf9702c947132"

  # Add your dependencies
  depends_on "poetry"
  depends_on "gh"
  depends_on "fd"
  depends_on "ripgrep"  # this is the package name for 'rg'

  def install
    libexec.install Dir["*"]

    # Create a symlink from .env to the user's config
    cd libexec do
      system "poetry", "install"
      # Remove any existing .env
      rm_f ".env"
      # Create symlink
      system "ln", "-sf", "$HOME/.friday_autocoder.env", ".env"
    end

    (bin/"friday_autocoder").write <<~EOS
      #!/bin/bash
      if [ ! -f $HOME/.friday_autocoder.env ]; then
        echo "No config file found at ~/.friday_autocoder.env"
        echo "Please create one with your required environment variables"
        exit 1
      fi
      exec #{libexec}/bin/run "$@"
    EOS

    chmod 0755, bin/"friday_autocoder"
  end

  def post_install
    puts "\n📝 Configuration Required:"
    puts "Create ~/.friday_autocoder.env with your environment variables:"
    puts "Example:"
    puts "  OPENAI_API_KEY=your_key_here"
    puts "  ANTHROPIC_API_KEY=your_token_here"
    puts "\nRun 'friday_autocoder <base_path>' after setting up your config file"
  end

  test do
    system "#{bin}/friday_autocoder", "--version"
  end
end

