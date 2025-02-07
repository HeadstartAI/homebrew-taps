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
    # Install the entire package into libexec
    libexec.install Dir["*"]

    # Run poetry install in the libexec directory
    cd libexec do
      system "poetry", "install"
    end

    # Create a wrapper script in bin that sets up the correct environment
    (bin/"friday_autocoder").write <<~EOS
      #!/bin/bash
      cd #{libexec} && exec ./bin/run "$@"
    EOS

    # Make it executable
    chmod 0755, bin/"friday_autocoder"
  end

  test do
    system "#{bin}/friday_autocoder", "--version"
  end
end

