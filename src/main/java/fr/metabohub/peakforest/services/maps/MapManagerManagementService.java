package fr.metabohub.peakforest.services.maps;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;

import fr.metabohub.peakforest.dao.maps.ExtraDbSessionFactoryManager;
import fr.metabohub.peakforest.dao.maps.MapManagerDao;
import fr.metabohub.peakforest.model.maps.MapManager;

/**
 * @author Nils Paulhe
 * 
 */
public class MapManagerManagementService {

	/**
	 * @param newMapManager
	 * @return
	 * @throws Exception
	 */
	public static long create(MapManager newMapManager) throws Exception {
		SessionFactory extraDbSessionFactory = ExtraDbSessionFactoryManager.getInstance()
				.getExtraDbSessionFactory();
		Long id = null;
		Session session = extraDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			id = create(session, newMapManager);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return id;
	}

	/**
	 * @param session
	 * @param mapManager
	 * @return
	 */
	public static Long create(Session session, MapManager mapManager) {
		long id = MapManagerDao.create(session, mapManager);
		return id;
	}

	// /**
	// * @param id
	// * @return
	// * @throws Exception
	// */
	// public static MapManager read(Short id) throws Exception {
	// SessionFactory extraDbSessionFactory = ExtraDbSessionFactoryManager.getInstance()
	// .getExtraDbSessionFactory();
	// return MapManagerDao.read(extraDbSessionFactory, id);
	// }

	/**
	 * @param session
	 * @param mapSource
	 * @return
	 * @throws Exception
	 */
	public static MapManager read(Session session, Short mapSource) throws Exception {
		return MapManagerDao.read(session, mapSource);
	}

	/**
	 * @param mapManagerMail
	 * @return
	 * @throws Exception
	 */
	public static MapManager read(Short mapSource) throws Exception {
		SessionFactory extraDbSessionFactory = ExtraDbSessionFactoryManager.getInstance()
				.getExtraDbSessionFactory();
		return MapManagerDao.read(extraDbSessionFactory, mapSource);
	}

	public static boolean exists(Short mapManagerSource) throws Exception {
		boolean exists = false;
		SessionFactory extraDbSessionFactory = ExtraDbSessionFactoryManager.getInstance()
				.getExtraDbSessionFactory();
		Session session = extraDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			exists = MapManagerDao.exists(session, mapManagerSource);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return exists;
	}

	public static List<MapManager> readAll() throws Exception {
		SessionFactory extraDbSessionFactory = ExtraDbSessionFactoryManager.getInstance()
				.getExtraDbSessionFactory();
		return MapManagerDao.readAll(extraDbSessionFactory);
	}

	/**
	 * @param mapSource
	 * @return
	 * @throws Exception
	 */
	public static boolean delete(Short mapSource) throws Exception {
		SessionFactory extraDbSessionFactory = ExtraDbSessionFactoryManager.getInstance()
				.getExtraDbSessionFactory();
		Session session = extraDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			MapManagerDao.delete(session, mapSource);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

}
