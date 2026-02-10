cask "brew-services-manager" do
  version "1.1.8"
  sha256 "67eac8e3a0a71b96c8598efa57f6838c70a395b5dc1f28dc2a46fad856dfd06d"

  url "https://github.com/validatedev/BrewServicesManager/releases/download/v#{version}/BrewServicesManager-#{version}.dmg"
  name "Brew Services Manager"
  desc "Native menu bar app for managing Homebrew services"
  homepage "https://github.com/validatedev/BrewServicesManager"

  livecheck do
    url "https://raw.githubusercontent.com/validatedev/BrewServicesManager/main/appcast.xml"
    strategy :sparkle, &:short_version
  end

  auto_updates true
  depends_on macos: ">= :sequoia"

  app "Brew Services Manager.app"

  zap trash: [
    "~/Library/Application Support/dev.mertcandemir.BrewServicesManager",
    "~/Library/Caches/dev.mertcandemir.BrewServicesManager",
    "~/Library/HTTPStorages/dev.mertcandemir.BrewServicesManager",
    "~/Library/Preferences/dev.mertcandemir.BrewServicesManager.plist",
    "~/Library/Saved Application State/dev.mertcandemir.BrewServicesManager.savedState",
  ]
end
