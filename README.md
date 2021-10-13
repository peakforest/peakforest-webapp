PeakForest - WebApp
=======

Metadata
-----------

 * **@name**: PeakForest - WebApp
 * **@version**: 2.0
 * **@authors**: Nils Paulhe <nils.paulhe@inra.fr>
 * **@date creation**: 2014/01/23
 * **@main usage**: PeakForest web-application; for further informations, please refer to [peakforest.org](https://peakforest.org/aboutPF) 

Configuration
-----------

### Requirement:
 * Tomcat7+ server
 * JVM 1.8
 * [Open Babel](http://openbabel.org/wiki/Main_Page) 
    * version 2.3.2, with java bundle
    * version 40bc0f10 (cf doc)
 * Webservice Dependencies:
    * NCBI
    * EBI
    * ChemSpider
    
 * You must have the following jar into `lib` directory (replace `X` with the current version number):
    * externalbanks-api-X.jar (*via* [externalbanks-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/externalbanks-api))
    * externaltools-api-X.jar (*via* [externaltools-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/externaltools-api))
    * io-chemfile-api-X.jar (*via* [io-chemfile-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/io-chemfile-api))
    * io-spectrafile-api-X.jar (*via* [io-spectrafile-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/io-spectrafile-api))
    * peakforest-api-X.jar (*via* [peakforest-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/peakforest-api))
    * peakforest-datamodel-X.jar (*via* [peakforest-datamodel-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/peakforest-datamodel-api))
    * peakforest-license-manager-X_out.jar (*via* [peakforest-license-manager-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/peakforest-license-manager-api))
    * peakforest-peakmatching-api-X.jar (*via* [peakforest-peakmatching-api-api](https://pfemw3.clermont.inra.fr/gitlab/dev-team/peakforest-peakmatching-api))
    * openbabel.jar (*via* [openbabel](https://github.com/openbabel/openbabel))
    * reader.jar (*via* [jnmrread](https://bitbucket.org/peakforestmodule/jnmrread))

### Deploy:
 * get project data `git clone git@pfemw3.clermont.inra.fr:dev-team/peakforest-webapp.git`
 * config files:
    * `src/main/resources/conf.properties`
    * `src/main/resources/hibernate-metadb.cfg.xml`
    * `src/main/resources/hibernate.cfg.xml`
    * `src/main/resources/info.properties`
    * `src/main/resources/hibernate-extradb.cfg.xml`
    * `src/main/resources/server/metExploreData.json`

### Warning:
See [git@pfemw3.clermont.inra.fr:dev-team/doc-metabohub.git](main documentation) for Open Babel and Databases configuration.

Services provided
-----------

 * chemical compound library manager
 * spectra library manager
 * spectrum viewers
 * curation interface
 * admin interface

NMR viewer with Docker wrapper
-----------

The NMR spectra viewer `NMR pro` run on a python server. 
In order to avoid install issues and socket conflict, it is isolated in a Docker container. 
Run the docker container with the following command:
```bash
docker run \
  -d \ # mode deamon
  -p 127.0.0.1:8000:8000 \ # redirect port
  -v /peakforest/data/nmr_spectra/raw:/mnt/raw_spectra \ # mount volum in the docker container
  npaulhe/nmrpro python nmrpro_server/manage.py runserver 0.0.0.0:8000 \ # run command
```

Developper notes
-----------

You should open your MySQL socket on your computer for the local tests.

Licenses
-----------

 * Frameworks:
   * Spring / Spring Security - http://projects.spring.io/spring-framework/
   * Bootstrap - http://getbootstrap.com/
   * GLmol - Molecular Viewer on WebGL/Javascript - http://webglmol.sourceforge.jp/index-en.html
 * Templates:
   * SB Admin - http://startbootstrap.com/template-overviews/sb-admin/
