package fr.metabohub.peakforest.utils;

import java.util.ResourceBundle;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;

import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 *
 */
public class UpdateMassVsLogPStatsTest {

	@Rule
	public TestName name = new TestName();

	public Logger logger = Logger.getRootLogger();
	public static SessionFactory testSessionFactory;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
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
	public void test() {
		// display log
		logger.info("[junit test] " + name.getMethodName() + " -> begin");
		long beforeTime = System.currentTimeMillis();

		// MetExploreRequestJob test = new MetExploreRequestJob();
		try {
			UpdateMassVsLogPStats.updateMassVsLogPstats();
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[fatal] exception occured");
		}

		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] " + name.getMethodName() + " -> end, tested in " + checkDuration + " sec.");
	}

}
