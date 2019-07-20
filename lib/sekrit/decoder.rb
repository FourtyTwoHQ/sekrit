require 'base64'
require 'openssl'
require 'securerandom'

module Sekrit

    class Decoder

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
        def decode(string: String)
            data = Base64.decode64(string)
            salt = data[8..15]
            data = data[16..-1]

            decipher = OpenSSL::Cipher.new('AES-256-CBC')
            decipher.decrypt
            decipher.pkcs5_keyivgen(@password, salt, 1, "MD5")

            decipher.update(data) + decipher.final
        end
    end

end