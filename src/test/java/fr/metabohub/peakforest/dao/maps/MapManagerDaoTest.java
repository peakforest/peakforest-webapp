package fr.metabohub.peakforest.dao.maps;

import java.util.ResourceBundle;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import fr.metabohub.peakforest.model.maps.MapEntity;
import fr.metabohub.peakforest.model.maps.MapManager;
import fr.metabohub.peakforest.utils.Utils;

public class MapManagerDaoTest {

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
					.getBundleConfElement("hibernate.extradb.configuration.file"));
			configuration.setProperty("hibernate.connection.url",
					"jdbc:" + Utils.getBundleConfElement("hibernate.connection.extra.database.type") + "://"
							+ Utils.getBundleConfElement("hibernate.connection.extra.database.host") + "/"
							+ Utils.getBundleConfElement("hibernate.connection.extra.database.dbName"));
			configuration.setProperty("hibernate.connection.extra.username",
					Utils.getBundleConfElement("hibernate.connection.extra.database.username"));
			configuration.setProperty("hibernate.connection.extra.password",
					Utils.getBundleConfElement("hibernate.connection.extra.database.password"));
			ServiceRegistry serviceRegistry = new ServiceRegistryBuilder().applySettings(
					configuration.getProperties()).buildServiceRegistry();
			testSessionFactory = configuration.buildSessionFactory(serviceRegistry);
		} catch (Throwable ex) {
			System.err.println("Initial SessionFactory creation failed.");
			ex.printStackTrace();
			throw new Exception(ex);
		}
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		// display log
		logger.info("[junit test] mapManagerDaoTest -> begin");
		long beforeTime = System.currentTimeMillis();

		// testSessionFactory
		if (MapManagerDao.exists(testSessionFactory, MapManager.MAP_METEXPLORE))
			MapManagerDao.delete(testSessionFactory, MapManager.MAP_METEXPLORE);

		MapManager test = new MapManager(MapManager.MAP_METEXPLORE);
		test.addMapEntities(new MapEntity(test));
		test.addMapEntities(new MapEntity(test));
		test.addMapEntities(new MapEntity(test));

		MapManagerDao.create(testSessionFactory, test);

		MapManager test2 = MapManagerDao.read(testSessionFactory, MapManager.MAP_METEXPLORE);

		Assert.assertEquals("[error]", test2.getMapEntities().size(), 3);

		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] mapManagerDaoTest -> end, tested in " + checkDuration + " sec.");
	}

}
