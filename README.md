[![pipeline status](https://services.pfem.clermont.inra.fr/gitlab/peakforest/peakforest-webapp/badges/dev/pipeline.svg)](https://services.pfem.clermont.inra.fr/gitlab/peakforest/peakforest-webapp/commits/dev)

# PeakForest - WebApp

## Metadata

* authors: <nils.paulhe@inrae.fr>, <franck.giacomoni@inrae.fr>
* creation date: `2014-01-23`
* main usage:  PeakForest web-application; for further informations, please refer to [peakforest.org](https://peakforest.org/) 

## Getting Started

This project uses and requires:
- java JVM 1.8+
- maven 4+
- MySQL 5+

- [Open Babel](http://openbabel.org/wiki/Main_Page) 
    - version `2.3.2`, with java bundle
    - version `40bc0f10` (cf doc)
- Webservice Dependencies: see [PForest - Ext. Banks API](https://services.pfem.clermont.inra.fr/gitlab/peakforest/externalbanks-api) for further details

### Prerequisites

Use [STS](https://spring.io/tools) IDE.

### Install / Build

- get project data `git clone git@services.pfem.clermont.inra.fr:peakforest/peakforest-webapp.git`
- Build command `mvn clean install` produce:
   - `peakforest-webapp-X.war` (java bin file, ready for a tomcat server deploy; `X` matching the current version number)

## Running the tests

Run `mvn test` command to launch all unit test.\
You can also select a test class / package in STS or Eclipse package explorer and launch test using right click option.

<!-- 
### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [GitLab](https://services.pfem.clermont.inra.fr/gitlab/your/project) for versioning. 
For the versions available, see the [tags on this repository](https://services.pfem.clermont.inra.fr/gitlab/your/project/tags). 

## Authors

* **Firstname lastname** - *Initial work* - 

See also the list of [contributors](https://services.pfem.clermont.inra.fr/gitlab/your/projectcontributors) who participated in this project.

## License

This project is licensed under the XXX License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
-->

### Deploy

- get project data `git clone git@services.pfem.clermont.inra.fr:peakforest/peakforest-webapp.git`
- configuration files:
   - `src/main/resources/conf.properties`
   - `src/main/resources/info.properties`
   - `src/main/resources/hibernate.cfg.xml`
   - `src/main/resources/server/metExploreData.json`

### Warning

See [PForest - Developers documentation](https://services.pfem.clermont.inra.fr/gitlab/metabohub/doc-pforest_devs) for Open Babel and Databases configuration.

## Services provided


- chemical compound library manager
- spectra library manager
- spectrum viewers
- curation interface
- admin interface

### NMR viewer with Docker wrapper

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

## developers notes

You should open your MySQL socket on your computer for the local tests.

## Licenses

- Frameworks
   - Spring / Spring Security - http://projects.spring.io/spring-framework/
   - Bootstrap - http://getbootstrap.com/
- Binary tools
   - OpenBabel - The Open Source Chemistry Toolbox - http://openbabel.org/wiki/Main_Page
- JS tools
   - GLmol - Molecular Viewer on WebGL/Javascript - http://webglmol.sourceforge.jp/index-en.html
   - NMRPro - Python package for processing NMR Spectra - https://github.com/ahmohamed/nmrpro
- HTML/CSS Templates
   - SB Admin - http://startbootstrap.com/template-overviews/sb-admin/
