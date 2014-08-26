Coding Conventions
------------------
This list is not exhaustive and aims to serve as a guideline for getting your pull requests accepted. Please consider the following guidelines before submitting a pull request.

#### General Principles
Guidelines in this section should be considered **strong suggestions**, and are likely to be cited upon reviewing pull requests as blocking.

  1. `return` early.
  1. Use custom events sparingly.
  1. Favor composition over inheritance.
  1. Don't try/catch. Please, just don't.
  1. Favor iterators for complex cyclomatics.
  1. Favor multi-line strings when the length of the line would exceed 80 characters.
  1. Consider possible namespace collisions when choosing method names, especially for mixins.
  1. Allow constructors to be passed directly and referenced via factory definitions where possible.
  1. Use `@__factory()` instead of referencing `Oraculum` directly within a component's implemenation.

#### Style Guidelines
Guidelines in this section should be considered **suggestions**, and are less likely to be cited upon reviewing pull requests as blocking.

  1. Denote "protected" members by prefixing them with an underscore.
  1. Stash "private" methods in a closure to make them inaccessible outside of the local lexical scope.

Unit Tests
----------
This project aims to maintain > 90% unit test coverage. Please ensure that any contributions are thoroughly tested. Pull requests without unit tests will be rejected.

#### General Guidelines
Guidelines in this section should be considered **strong suggestions**, and are likely to be cited upon reviewing pull requests as blocking.

  1. Test the interface, not the implementation.
  1. Unit tests should maintain the same quality and readability as the code it describes.
  1. When in doubt, use the existing unit tests as an example.

Documentation
-------------
This project uses the grunt-docker module to generate its documentation. Docker supports the following js-doc style comment tags. Please use them.

  * `@see`: http://usejsdoc.org/tags-see.html
  * `@type`: http://usejsdoc.org/tags-type.html
  * `@param`: http://usejsdoc.org/tags-param.html
  * `@return`: http://usejsdoc.org/tags-returns.html

No documentation tool is not without its flaws. Please keep the following guidelines in mind when authoring your documentation.

  1. Don't start any line of a multi-line string with `#`.
  1. Use H1 (`#`, `===`) at the top of a file to denote the component's name.
  1. Use H2 (`##`, `---`) above first-level component properties to denote these properties.
  1. Use H3... above subcomponent properties (internal/protected properties) to denote these properties, and situate them beneath their related interface.

Legal
-----

Thanks for your interest in the Oraculum project.  When you make a contribution to the project (e.g. any modifications, additions to existing work, pull requests or any other work intentionally submitted by you for inclusion in the project) (collectively, a "Contribution"), Lookout wants to be able to use your Contribution to improve this project and other Lookout products.

As a condition of providing a Contribution, you agree to the following terms and conditions (“Terms”):

  1. Copyright License: Subject to these Terms, you grant Lookout and to recipients of software distributed by Lookout a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable license to make, use, sell, reproduce, modify, distribute (directly and indirectly), and publicly display and perform the Contribution, and any derivative works that Lookout may make from the Contribution.

  2. Patent License: Subject to these Terms, you grant Lookout and to recipients of software distributed by Lookout a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable (except as stated in this section) patent license to make, have made, use, offer to sell, sell, import, or otherwise transfer the Contribution, where such license applies only to those patent claims licensable by you that are necessarily infringed by your Contribution(s) alone or by combination of your Contribution(s) with any works or projects to which such Contribution(s) was submitted. If any entity institutes patent litigation against you or any other entity (including a cross-claim or counterclaim in a lawsuit) alleging that your Contribution(s) or the projects to which you have contributed, constitutes direct or contributory patent infringement, then any patent licenses granted to that entity under this agreement for that Contribution, work or other project shall terminate as of the date such litigation is filed.

  3. You warrant and represent that the Contribution(s) is your original creation, that you have the authority and are legally entitled to grant these licenses to Lookout, and that these licenses do not require the permission of any third party.

  4. Except for the warranties in Section 3, you provide any Contribution(s) on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied, including, without limitation, any warranties or conditions of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.

  5. You agree to notify Lookout of any facts or circumstances of which you become aware of that would make any representations made by you inaccurate in any respect.


Should you wish to submit a suggestion or work that is not your original creation, you may submit it to Lookout separate from any Contribution, explicitly identifying it as sourced from a third party, stating the complete details of its source, and informing Lookout of any license or other restriction (including but not limited to related patents, trademarks, and license agreement) of which you are personally aware, and conspicuously marking the work as “Submitted on behalf of a third party: [named here].”
