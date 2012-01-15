omniauth-nate
=============

Nate를 위한 omniauth strategy입니다. Nate/Cyworld/Empas 계정을 이용한 인증이 가능하도록 합니다.

http://www.nate.com

설치
----

Gemfile 에 추가 후,

```ruby
gem 'omniauth-nate'
```

`bundle install`

사용 절차
---------

Nate의 devsquare에서 consumer key를 발급 받습니다.

http://devsquare.nate.com/

발급 확인 메일을 통해 `GetNateMemberInfo` API 의 결과를 복호화하는 필요한 
encryption key와 IV를 함께 할당받게 됩니다.

### Usage

OAuth를 위한 consumer key, secret과 함께 발급 확인 메일을 통해 부여받은
encryption key를 기재합니다.

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :nate, consumer_key, consumer_secret, 
      :encryption => {
        :key => key,                  # Required.
        :iv  => 0.chr * 8,            # Optional. Default: 0.chr * 8
        :algorithm => 'des-ede3-cbc'  # Optional. Default: des-ede3-cbc
      }
end
```

### Devise 에서의 설정

```ruby
Devise.setup do |config|
  config.omniauth :nate, consumer_key, consumer_secret,
      :encryption => {
        :key => key,                  # Required.
        :iv  => 0.chr * 8,            # Optional. Default: 0.chr * 8
        :algorithm => 'des-ede3-cbc'  # Optional. Default: des-ede3-cbc
      }
end
```

Authentication Hash
-------------------

이메일 주소가 User identifier로 사용됩니다.

```ruby
{
  :provider => 'nate',
  :uid      => 'your-mail@nate.com',
  :info     => {
    :name   => 'your name',
    :email  => 'your-mail@nate.com'
  }
}
```

Contributing to omniauth-nate
-----------------------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

License
-------
Copyright (c) 2012 Junegunn Choi

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
