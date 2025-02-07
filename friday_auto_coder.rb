class FridayAutoCoder < Formula
  desc "Friday AutoCoder"
  homepage "https://github.com/HeadstartAI/auto_coder"
  url "https://raw.githubusercontent.com/HeadstartAI/auto_coder/1.1/archive.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"

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

