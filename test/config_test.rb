require "test_helper"

class ConfigTest < Minitest::Test

  def setup
    @config = Sekrit::Config.new(path: '../../test/Sekritfile')
  end

  def test_that_it_has_a_version_number
    refute_nil ::Sekrit::VERSION
  end

  def test_it_loads_repo_property
    assert_equal @config.repo, 'git@github.com:bsarrazin/Sekrit-iOS-Sekrit.git'
  end

  def test_it_loads_passphrase_property
    assert_equal @config.passphrase, 'SEKRIT_PASSPHRASE'
  end

  def test_it_loads_bundles_property
    expected = [
      'io.fourtytwo.Sekrit',
      'io.fourtytwo.Sekrit.beta',
      'io.fourtytwo.Sekrit.alpha'
    ]
    assert_equal expected.sort, @config.bundles.map { |b| b.name }.sort
  end

  def test_it_loads_bundled_files_files_property
    expected_files = [
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon@2x.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon@3x.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon1024.jpg',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon40.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon40@2x.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon40@3x.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon60@2x.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon60@3x.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon76.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon76@2x.png',
      'Sekrit/Resources/Assets.xcassets/AppIcon.appiconset/Icon83.5@2x.png'
    ]

    assert_equal expected_files.sort, @config.bundled_files.files.sort
  end

  def test_it_loads_bundled_files_encrypted_property
    expected_encrypted = [
      'Sekrit/Source/Sekrit/Secrets.swift',
      'Sekrit/Supporting Files/Sekrit.debug.xcconfig',
      'Sekrit/Supporting Files/Sekrit.release.xcconfig'
    ]

    assert_equal expected_encrypted.sort, @config.bundled_files.encrypted.sort
  end

  def test_it_loads_shared_files_files_property
    assert_nil @config.shared_files.files
  end

  def test_it_loads_shared_files_encrypted_property
    expected_encrypted = [
      'Sekrit/Supporting Files/Shared.debug.xcconfig',
      'Sekrit/Supporting Files/Shared.release.xcconfig'
    ]

    assert_equal expected_encrypted.sort, @config.shared_files.encrypted.sort
  end

end
