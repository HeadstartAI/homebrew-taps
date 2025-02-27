class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/friday_releases"
  version "stable"
  revision 7

  on_arm do
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/assets/233115620", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "de92394f82eb50e805a94e64d8ab309f57b6a2e7b2646229e49f71051326dd17"
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
  end

  def post_install
    puts "\n📝 Configuration Required:"
    puts "1. Login to GitHub CLI:"
    puts "   gh auth login"
    puts "\nRun 'friday <base_path>' after completing the setup."
  end

  test do
    system "#{bin}/friday"
  end
end
