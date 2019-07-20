require 'base64'
require 'openssl'
require 'securerandom'

module Sekrit

    class Encoder

        def initialize(password: String)
            @password = password
        end

        # [bsarrazin] July 20th, 2019
        # Stolen from Fastlane, as I am not an expert on encryption/decryption.
        # If you have experience and want to help, please submit a pull request :)
        #
        # > We encrypt with MD5 because that was the most common default value in older fastlane versions which used the local OpenSSL installation
        # > A more secure key and IV generation is needed in the future, IV should be randomly generated and provided unencrypted
        # > salt should be randomly generated and provided unencrypted (like in the current implementation)
        # > key should be generated with OpenSSL::KDF::pbkdf2_hmac with properly chosen parameters
        # > Short explanation about salt and IV: https://stackoverflow.com/a/1950674/6324550
        def encode(string: String)

            salt = SecureRandom.random_bytes(8)

            cipher = OpenSSL::Cipher.new('AES-256-CBC')
            cipher.encrypt
            cipher.pkcs5_keyivgen(@password, salt, 1, "MD5")
            data = "Salted__" + salt + cipher.update(string) + cipher.final

            Base64.encode64(data)
        end
    end

end