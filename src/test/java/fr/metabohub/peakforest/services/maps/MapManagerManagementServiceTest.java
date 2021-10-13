package fr.metabohub.peakforest.services.maps;

import java.util.ResourceBundle;

import org.apache.log4j.Logger;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import fr.metabohub.peakforest.model.maps.MapEntity;
import fr.metabohub.peakforest.model.maps.MapManager;
import fr.metabohub.peakforest.utils.Utils;

public class MapManagerManagementServiceTest {
	public Logger logger = Logger.getRootLogger();

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		// set test properties file
		Utils.setBundleConf(ResourceBundle.getBundle("confTest"));
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
	public void test() throws Exception {
		// fail("Not yet implemented");
		logger.info("[junit test] mapManagerServiceTest -> begin");
		long beforeTime = System.currentTimeMillis();

		// testSessionFactory
		if (MapManagerManagementService.exists(MapManager.MAP_METEXPLORE))
			MapManagerManagementService.delete(MapManager.MAP_METEXPLORE);

		MapManager test = new MapManager(MapManager.MAP_METEXPLORE);
		test.addMapEntities(new MapEntity(test));
		test.addMapEntities(new MapEntity(test));
		test.addMapEntities(new MapEntity(test));

		MapManagerManagementService.create(test);

		MapManager test2 = MapManagerManagementService.read(MapManager.MAP_METEXPLORE);

		Assert.assertEquals("[error]", test2.getMapEntities().size(), 3);

		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] mapManagerServiceTest -> end, tested in " + checkDuration + " sec.");
	}

}
