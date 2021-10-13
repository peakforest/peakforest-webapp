/**
 * 
 */
package fr.metabohub.peakforest.security.services;

import static org.junit.Assert.fail;

import java.util.ResourceBundle;

import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.dao.UserDao;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.utils.PeakForestUtils;

/**
 * Test class for {@link UserManagementService} service methods
 * 
 * @author Nils Paulhe
 * 
 */
public class UserManagementServiceTest {

	@BeforeClass
	public static void setUpBeforeClass() {
		PeakForestUtils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	/**
	 * Test all methods
	 * 
	 * @throws Exception
	 */
	@Test
	public void userManagementServiceTest() throws Exception {

		// if exist => delete
		if (UserManagementService.exists("nils.paulhe@inra.fr"))
			UserManagementService.delete("nils.paulhe@inra.fr");
		if (UserManagementService.exists("franck.giacomoni@inra.fr"))
			UserManagementService.delete("franck.giacomoni@inra.fr");
		if (UserManagementService.exists("niel.maccormack@hero-corp.com")) {
			UserManagementService.delete("niel.maccormack@hero-corp.com");
			Assert.fail("[warning] user not deleted in previous tests.");
		}

		// password generation
		StandardPasswordEncoder encoder = new StandardPasswordEncoder();

		// test create
		User franck = new User();
		franck.setLogin("franck");
		franck.setEmail("franck.giacomoni@inra.fr");
		franck.setPassword(encoder.encode("franckTestPassword"));
		long idFranck = UserManagementService.create(franck);

		User nils = new User();
		nils.setLogin("nils");
		nils.setEmail("nils.paulhe@clermont.inra.fr");
		nils.setPassword(encoder.encode("nilsTestPassword"));
		long idNils = UserManagementService.create(nils);

		User niel = new User();
		niel.setLogin("niel");
		niel.setEmail("niel.maccormack@hero-corp.com");
		niel.setPassword(encoder.encode("nielTestPassword"));
		long idNiel = UserManagementService.create(niel);

		// test update
		User franckFromDB = UserDao.read(idFranck);
		franckFromDB.setLogin("franck_login");
		franckFromDB.setAdmin(true);
		if (!UserManagementService.update(franckFromDB))
			fail("[fail] could not update user");

		if (!UserManagementService.updateAdmin(idNils, "toto", "nils.paulhe@inra.fr", User.ADMIN))
			fail("[fail] could not update user");

		// test delete
		if (!UserManagementService.delete(idNiel))
			fail("[fail] could not delete user");

	}
}
