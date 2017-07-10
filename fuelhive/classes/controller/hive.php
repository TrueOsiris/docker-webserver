<?php

class Controller_Hive extends Controller
{
	public function action_index()
	{
		$manager_files = File::read_dir('/synced/www/managers', 0, array('!^\.')); 
		foreach ($manager_files as $manager) {
			${$manager}=File::read('/synced/www/managers/'.$manager,true);
			$managers[]=$manager;
		}
	
		View::set_global('managers', $managers);
		return Response::forge(View::forge('hive/index'));
	}

	public function action_hello()
	{
		return Response::forge(Presenter::forge('welcome/hello'));
	}

	public function action_404()
	{
		return Response::forge(Presenter::forge('welcome/404'), 404);
	}
	
}
