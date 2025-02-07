class FridayAutoCoder < Formula
  desc "Friday AutoCoder"
  homepage "https://github.com/HeadstartAI/auto_coder"
  url "https://api.github.com/repos/HeadstartAI/auto_coder/tarball/1.1"
  sha256 "f3450ceffb845eb13bd525dac83655bc5b50b18d5519e7c83aadf9702c947132"

  # Add your dependencies
  depends_on "poetry"
  depends_on "gh"
  depends_on "fd"
  depends_on "ripgrep"  # this is the package name for 'rg'

  def install
    # Run poetry install
    system "poetry", "install"

    # Install your script
    bin.install "bin/run" => "run"

    # Make the script executable
    system "chmod", "+x", "#{bin}/run"
  end

  test do
    system "#{bin}/run"
  end
end

