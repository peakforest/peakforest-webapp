package fr.metabohub.peakforest.dao.maps;

import java.util.ResourceBundle;

import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

import fr.metabohub.peakforest.model.maps.MapEntity;
import fr.metabohub.peakforest.model.maps.MapManager;
import fr.metabohub.peakforest.utils.PeakForestUtils;

public class MapManagerDaoTest {

	/**
	 * Set class' static param.
	 */
	@BeforeClass
	public static void setUpBeforeClass() {
		// set config file
		PeakForestUtils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	@Test
	public void test() {
		if (MapManagerDao.exists(MapManager.MAP_METEXPLORE)) {
			MapManagerDao.delete(MapManager.MAP_METEXPLORE);
		}
		final MapManager test = new MapManager(MapManager.MAP_METEXPLORE);
		test.addMapEntities(new MapEntity(test));
		test.addMapEntities(new MapEntity(test));
		test.addMapEntities(new MapEntity(test));
		MapManagerDao.create(test);
		final MapManager test2 = MapManagerDao.read(MapManager.MAP_METEXPLORE);
		Assert.assertEquals(3, test2.getMapEntities().size(), 0);

	}

}
