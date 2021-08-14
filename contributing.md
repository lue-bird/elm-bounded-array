## contributing 💙

- suggest changes through pull requests
- discuss bigger changes in an issue or in a github Discussion 

## you can

- share your thoughts
- add tests
- add operations that might be useful
    - notes:
        - `Arr.from1` to `from16` and `Arr.to2` to `Arr.to14` and the module `Arguments` are [generated using elm](generate/src/GenerateForElmBoundedArray.elm)
        - `Array` has no native sort function
            - if `elm-community/array-extra` or `elm/core` ([issue for elm-community](https://github.com/elm-community/array-extra/issues/25), [issue for core](https://github.com/elm/core/issues/1112)) introduce sorting operations, these will also be added here
        - run `elm-review` and `elm-test` before creating a PR
        - you don't need to `elm-verify-examples`

## commits
look like this:
> do details, make other details & this

| mark     | means   |
| :------- | :------ |
| + ...    | add     |
| - ...    | remove  |
| +- ...   | change  |
| ↻ ...    | update  |
| ✓ ...    | correct |
| -< ...   | split   |
| >- ...   | merge   |
