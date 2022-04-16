const RootPortal = artifacts.require('./RootPortal');
const ChildPortal = artifacts.require('./ChildPortal');

module.exports = async function (deployer) {
  await deployer.deploy(RootPortal);
  await deployer.deploy(ChildPortal);
};
