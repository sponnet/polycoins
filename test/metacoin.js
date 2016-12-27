contract('PolyCoins', function(accounts) {
  var polycoinscontract;
  var token_buyer = accounts[0];

  var self = this;

  describe('Deploy PolyCoins token', function() {
    it("should deploy PolyCoins contract", function(done) {

      PolyCoins.new(
        1, 1, 1, 1, 1, 1, 1e18
      ).then(function(instance) {
        self.polycoinscontract = instance;
        assert.isNotNull(polycoinscontract);
        done();
      });
    });


    it("token_buyer should have 0 PolyCoins tokens", function(done) {
      return self.polycoinscontract.balanceOf.call(token_buyer).then(function(balance) {
        assert.equal(balance.valueOf(), 0, "account not empty");
        done();
      });
    });

    it("should accept ETH and mint tokens", function(done) {

      console.log('tokenbuyer ETH balance=', self.web3.fromWei(self.web3.eth.getBalance(token_buyer), 'ether').toNumber());

      self.web3.eth.sendTransaction({
        from: token_buyer,
        to: self.polycoinscontract.address,
        value: 1e18,
      }, function(r, s) {
        try {

          done();
        } catch (e) {
          assert.fail('this function should not throw');
          done();
        }
      });
    });


    it("token_buyer should have tokens", function(done) {
      console.log('tokenbuyer ETH balance=', self.web3.fromWei(self.web3.eth.getBalance(token_buyer), 'ether').toNumber());
      self.polycoinscontract.balanceOf.call(token_buyer).then(function(balance) {
        console.log('balance', balance.valueOf());
        assert.isNotNull(balance.valueOf(), "purchase did not work");
        process.exit();
        done();
      });
    });
  });
});