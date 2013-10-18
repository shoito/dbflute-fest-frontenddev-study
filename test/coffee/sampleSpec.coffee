describe "mochaサンプル", ->
    it "テストが実行される", ->
        fdev.sayHello().should.equal "hello"

    it "連続的にテストが実行される", ->
        fdev.sayGoodby().should.equal "good-by"