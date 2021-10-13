/**
 * 
 */
package fr.metabohub.peakforest.security.dao;

import java.util.ResourceBundle;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
public class UserDaoTest {

	public Logger logger = Logger.getRootLogger();
	public static SessionFactory testSessionFactory;

	/**
	 * @throws java.lang.Exception
	 */
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		// set test properties file
		Utils.setBundleConf(ResourceBundle.getBundle("confTest"));
		try {
			// manual configuration
			Configuration configuration = new Configuration().configure(Utils
					.getBundleConfElement("hibernate.metadb.configuration.file"));
			configuration.setProperty("hibernate.connection.url",
					"jdbc:" + Utils.getBundleConfElement("hibernate.connection.meta.database.type") + "://"
							+ Utils.getBundleConfElement("hibernate.connection.meta.database.host") + "/"
							+ Utils.getBundleConfElement("hibernate.connection.meta.database.dbName"));
			configuration.setProperty("hibernate.connection.meta.username",
					Utils.getBundleConfElement("hibernate.connection.meta.database.username"));
			configuration.setProperty("hibernate.connection.meta.password",
					Utils.getBundleConfElement("hibernate.connection.meta.database.password"));
			ServiceRegistry serviceRegistry = new ServiceRegistryBuilder().applySettings(
					configuration.getProperties()).buildServiceRegistry();
			testSessionFactory = configuration.buildSessionFactory(serviceRegistry);
		} catch (Throwable ex) {
			System.err.println("Initial SessionFactory creation failed.");
			ex.printStackTrace();
			throw new Exception(ex);
		}
	}

	/**
	 * @throws java.lang.Exception
	 */
	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void userDaoTest() {
		// display log
		logger.info("[junit test] userDaoTest -> begin");
		long beforeTime = System.currentTimeMillis();

		// if exist => delete
		if (UserDao.exists(testSessionFactory, "npaulhe@clermont.inra.fr"))
			UserDao.delete(testSessionFactory, "npaulhe@clermont.inra.fr");
		if (UserDao.exists(testSessionFactory, "franck.giacomoni@clermont.inra.fr"))
			UserDao.delete(testSessionFactory, "franck.giacomoni@clermont.inra.fr");
		if (UserDao.exists(testSessionFactory, "niel.maccormack@hero-corp.com")) {
			UserDao.delete(testSessionFactory, "niel.maccormack@hero-corp.com");
			logger.error("[warning] user not deleted in previous tests.");
		}

		// password generation
		StandardPasswordEncoder encoder = new StandardPasswordEncoder();

		// test create
		User franck = new User();
		franck.setLogin("franck");
		franck.setEmail("franck.giacomoni@clermont.inra.fr");
		franck.setPassword(encoder.encode("franckTestPassword"));
		long idFranck = UserDao.create(testSessionFactory, franck);

		User nils = new User();
		nils.setLogin("nils");
		nils.setEmail("nils.paulhe@clermont.inra.fr");
		nils.setPassword(encoder.encode("nilsTestPassword"));
		UserDao.create(testSessionFactory, nils);

		User niel = new User();
		niel.setLogin("niel");
		niel.setEmail("niel.maccormack@hero-corp.com");
		niel.setPassword(encoder.encode("nielTestPassword"));
		long idNiel = UserDao.create(testSessionFactory, niel);

		// test update
		User franckFromDB = UserDao.read(testSessionFactory, idFranck);
		franckFromDB.setLogin("franck_login");
		franckFromDB.setAdmin(true);
		UserDao.update(testSessionFactory, franckFromDB);

		// if (!UserDao.updateAdmin(idNils, "npaulhe", "npaulhe@clermont.inra.fr", User.ADMIN))
		// fail("[fail] could not update user");

		// test delete
		UserDao.delete(testSessionFactory, idNiel);

		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] userDaoTest -> end, tested in " + checkDuration + " sec.");
	}
}
