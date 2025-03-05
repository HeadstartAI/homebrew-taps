class Friday < Formula
  desc "Friday"
  homepage "https://github.com/HeadstartAI/friday_releases"
  version "stable"
  revision 15

  on_arm do
    url "https://api.github.com/repos/HeadstartAI/friday_releases/releases/assets/234893780", using: :curl,
      follow_location: true,
      headers: ["Accept: application/octet-stream"]
    sha256 "8b317f1867dad34bbed03231d94f2f9356199a3e78de98ad35a10227b7773e0c"
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
