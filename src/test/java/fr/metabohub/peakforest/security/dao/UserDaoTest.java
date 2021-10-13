/**
 * 
 */
package fr.metabohub.peakforest.security.dao;

import org.junit.Assert;
import org.junit.Test;
import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.model.User;

/**
 * @author Nils Paulhe
 * 
 */
public class UserDaoTest {

	@Test
	public void userDaoTest() {
		// display log

		// if exist => delete
		if (UserDao.exists("nils.paulhe@inra.fr"))
			UserDao.delete("nils.paulhe@inra.fr");
		if (UserDao.exists("franck.giacomoni@inra.fr"))
			UserDao.delete("franck.giacomoni@inra.fr");
		if (UserDao.exists("niel.maccormack@hero-corp.com")) {
			UserDao.delete("niel.maccormack@hero-corp.com");
			Assert.fail("[ERROR] user not deleted in previous tests.");
		}

		// password generation
		StandardPasswordEncoder encoder = new StandardPasswordEncoder();

		// test create
		User franck = new User();
		franck.setLogin("franck");
		franck.setEmail("franck.giacomoni@inra.fr");
		franck.setPassword(encoder.encode("franckTestPassword"));
		long idFranck = UserDao.create(franck);

		User nils = new User();
		nils.setLogin("nils");
		nils.setEmail("nils.paulhe@inra.fr");
		nils.setPassword(encoder.encode("nilsTestPassword"));
		UserDao.create(nils);

		User niel = new User();
		niel.setLogin("niel");
		niel.setEmail("niel.maccormack@hero-corp.com");
		niel.setPassword(encoder.encode("nielTestPassword"));
		long idNiel = UserDao.create(niel);

		// test update
		User franckFromDB = UserDao.read(idFranck);
		franckFromDB.setLogin("franck_login");
		franckFromDB.setAdmin(true);
		UserDao.update(franckFromDB);

		// if (!UserDao.updateAdmin(idNils, "npaulhe", "nils.paulhe@inra.fr",
		// User.ADMIN))
		// fail("[fail] could not update user");

		// test delete
		UserDao.delete(idNiel);

	}
}
