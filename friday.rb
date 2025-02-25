class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/auto_coder"
  version "stable"
  revision 3

  on_arm do
    url "https://api.github.com/repos/HeadstartAI/auto_coder_releases/releases/assets/232520789", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream",
               "Authorization: token #{ENV['HOMEBREW_FRIDAY_GITHUB_API_TOKEN']}"]
    sha256 "5b41c267f1c6af2308b58bb4827807142b61ace0f36755657ec2ee5cfa07f3ed"
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
