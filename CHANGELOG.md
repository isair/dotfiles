#  (2020-12-31)


### Bug Fixes

* **profile:** make shared chruby config work on non-mac unix systems ([0b0f5e2](https://github.com/isair/dotfiles/commit/0b0f5e2164d4035652c6a9d394437c9085826ff1))
* **profiles:** fix nvm shell detection ([0724eba](https://github.com/isair/dotfiles/commit/0724eba5dce814286d2e2f549aff498ee1ccfec7))
* **profiles:** fix nvm shell detection ([12ae0ec](https://github.com/isair/dotfiles/commit/12ae0ec123a033442a4e9842fa62bc072bb80741))
* **profiles:** fix nvm shell detection ([ea7370b](https://github.com/isair/dotfiles/commit/ea7370bc37b41842c024a81c405cdd5860aee433))
* **profiles:** silence permission fix errors ([d8573be](https://github.com/isair/dotfiles/commit/d8573bedb9fa0ba31d8a53fcebc10733831f2c3b))
* **script:** force yes when installing apt packages ([cc7893b](https://github.com/isair/dotfiles/commit/cc7893be808f4ff26191764a572130fc63b42f41))
* **scripts:** fix os check and update script perms ([e12022d](https://github.com/isair/dotfiles/commit/e12022d797c7acf65a72c918bb0fc391bdae7d0e))
* **scripts:** missing locale in linux ([1d5455d](https://github.com/isair/dotfiles/commit/1d5455de87cb16f08d6178cf842c34e195e636ee))
* **scripts:** symlink correctly at the end of backup ([53e4647](https://github.com/isair/dotfiles/commit/53e464727e9a61692696603cee52254f58d834f5))
* **scripts:** use new way of listing casks ([43dd6a7](https://github.com/isair/dotfiles/commit/43dd6a70bc5a716a79cd1500b9b75b808b738977))


### Features

* **multi:** homebrew on linux ([55f8c68](https://github.com/isair/dotfiles/commit/55f8c68b274c998c72e442ffac1defd640efb611))
* **multi:** make it easier for people to create the default profile ([054d958](https://github.com/isair/dotfiles/commit/054d9587216afaec12b06a2c15f819eb1989d22c))
* **multi:** make rn profile work in codespaces ([2e86ccb](https://github.com/isair/dotfiles/commit/2e86ccb0ec31ab8d41ac0d95af9aa31eb3fd34e2))
* **profile:** support bash for nvm init ([c21471f](https://github.com/isair/dotfiles/commit/c21471f15a6581dc9ed474a13dc813d3bffd8fe6))
* **profiles:** update android studio paths ([1225d00](https://github.com/isair/dotfiles/commit/1225d009c400d289ec34cbafa56e4b77a4007179))
* **script:** implement checks for profile existence ([9ee5443](https://github.com/isair/dotfiles/commit/9ee54439a30c02136c5ba3ecb70068d06b97a24c))
* **scripts:** allow easy sharing of profiles between machines ([66468fa](https://github.com/isair/dotfiles/commit/66468fa12c1d8939400df288ecd99b8689ee9458))
* **scripts:** android fix cleanup ([fda8aa7](https://github.com/isair/dotfiles/commit/fda8aa7c01ad8ddf57760d4aa8cd423802857ee6))
* **scripts:** automate symlinking dotfiles to create a profile ([3f5353b](https://github.com/isair/dotfiles/commit/3f5353bbca32fa7208d6af93cce8ba9d821c92f0))
* **scripts:** improve modularity ([d0ea864](https://github.com/isair/dotfiles/commit/d0ea864a9a8ca504a1d97017f16743fb099d7e51))
* **scripts:** install chruby on ubuntu ([b03c162](https://github.com/isair/dotfiles/commit/b03c16284a33edb2e08066eec06d928d161b550f))
* **scripts:** install ruby-install on ubuntu ([d714db1](https://github.com/isair/dotfiles/commit/d714db11626f6e5969fe22f5c02606c9ba485de5))
* **scripts:** leave jdk installation to profiles ([7e5edfc](https://github.com/isair/dotfiles/commit/7e5edfc56270d828e669c446ea636461a919fec5))
* **scripts:** make backup work for all linux distros ([95e76af](https://github.com/isair/dotfiles/commit/95e76af281a84c18e45734c18dfee748de649c35))
* **scripts:** significantly speed up package installation ([4926c0e](https://github.com/isair/dotfiles/commit/4926c0eb324ac73aab19a839e2d0783ff9b9af8a))
* **scripts:** simplify linux installation using homebrew ([4c48554](https://github.com/isair/dotfiles/commit/4c485544e46f370c5cbcbf25986c7f8f7d1e35d6))
* **scripts:** unify cleanup logic and be more lenient overall ([4e143af](https://github.com/isair/dotfiles/commit/4e143af5e072a03038dd7c6b1fb6d8647ead4664))
* **scripts:** unify unix logic and make completely modular ([ee8fa5b](https://github.com/isair/dotfiles/commit/ee8fa5bee1a1f8ff18d5b116ab47d1ea64f70759))
* **scripts:** work for all linux distros ([81bfa50](https://github.com/isair/dotfiles/commit/81bfa50860a9d04923b1b20b063f403b1a04ac40))


### BREAKING CHANGES

* **scripts:** No tool is forced anymore. Scripts have also changed in
location and in how they work.




