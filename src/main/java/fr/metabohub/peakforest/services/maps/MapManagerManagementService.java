package fr.metabohub.peakforest.services.maps;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;

import fr.metabohub.peakforest.dao.maps.MapManagerDao;
import fr.metabohub.peakforest.model.maps.MapManager;
import fr.metabohub.peakforest.utils.PeakForestApiHibernateUtils;

/**
 * @author Nils Paulhe
 * 
 */
public class MapManagerManagementService {

	public static long create(MapManager newMapManager) throws Exception {
		Long id = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			id = create(session, newMapManager);
			transaction.commit();
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return id;
	}

	public static Long create(Session session, MapManager mapManager) {
		return MapManagerDao.create(session, mapManager);
	}

	public static MapManager read(Session session, Short mapSource) throws Exception {
		return MapManagerDao.read(session, mapSource);
	}

	public static MapManager read(Short mapSource) throws Exception {
		return MapManagerDao.read(mapSource);
	}

	public static boolean exists(Short mapManagerSource) throws Exception {
		boolean exists = false;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			exists = MapManagerDao.exists(session, mapManagerSource);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return exists;
	}

	public static List<MapManager> readAll() throws Exception {
		return MapManagerDao.readAll();
	}

	public static boolean delete(final Short mapSource) throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			MapManagerDao.delete(session, mapSource);
			transaction.commit();
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

}
