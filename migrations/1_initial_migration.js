const RootPortal = artifacts.require('./RootPortal');
const ChildPortal = artifacts.require('./ChildPortal');

/// Deploy the portals to the respective networks.
module.exports = async function (deployer) {
  switch (deployer.network) {
    case 'thetaNetwork':
      await deployer.deploy(ChildPortal);
      return;
    case 'rinkeby':
      await deployer.deploy(RootPortal);
  }
};
